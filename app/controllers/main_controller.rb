class MainController < ApplicationController
  
  include Util
  include DataOutputHelper
  
  filter_parameter_logging :password
  protect_from_forgery :only => [:create, :update, :destroy] 
  
  def index
    url = request.url
    if RAILS_ENV == 'production'
      redirect_to "#{url}/"
    else
      render :text => "not implemented in development mode"
    end
    
    #render :text => request.url
    #render :text => "#{url}/index.html"
  end
  
  
  # todo - in future, don't store email address in cookie, makes it too easy to fake a cookie.
  # instead, store some secure token
  def get_logged_in_user
    
    email = ''
    logger.info "cookies:"
    for v in cookies.values
      logger.info "\t#{v}, #{v.value}"
      if v.to_s =~ /echidna_cookie/
        logger.info "setting cookie..."
        cookies[:echidna_cookie] = {:value => v.value, :expires => 1000.days.from_now}
        session[:user] = v.value
        email = v.value
      end
    end
    
    if cookies[:echidna_cookie].nil? or cookies[:echidna_cookie].empty?
      logger.info "cookie is nil or empty"
      render :text => 'not logged in' and return false
    end
    if session['user'].nil?
      begin
        session['user'] = cookies['echidna_cookie']['value']
      rescue Exception => ex
        logger.info ex.message
        logger.info ex.backtrace
        logger.info "problem setting session user"
        render :text => "not logged in" and return false
      end
    end
    logger.info "returning #{email}"
    render :text => email
  end
  
  # todo make more secure
  
  
  def do_login(user)
    return "invalid user" unless user
    puts "in do_login, params[:email] is #{params[:email]}"
    user.last_login_date = Time.now
    user.save
    cookies[:echidna_cookie] = {:value => params[:email],
      :expires => 1000.days.from_now }
    session[:user] = params['email']
    session[:user_id] = user.id
    user.email
  end
  
  def login
    if (params[:token] and params[:reset_password]) #user is changing password
      user = User.find_by_email(params[:email])
      #user = User.find_by_sql(["select * from users where email = ?", params[:email]]).first
      if (Password::check("#{params[:email]}~~~#{SECRET_SALT}",params[:token]))
        user.password = params[:password]
        user.save
        
        render :text => do_login(user) and return false
      else
        user = nil
      end
    elsif params[:token] # user is validating account
      user = User.authenticate(params[:email], params[:password], false)
      render :text => "invalid login" and return false unless user
      if (Password::check("#{params[:email]}~~~#{SECRET_SALT}",params[:token]))
        user.validated = true
        user.save
        render :text => do_login(user) and return false
      else
        render :text => "invalid login" and return false
      end
    else # it's just a regular login
      user = User.authenticate(params[:email], params[:password]) 
    end



    render :text => do_login(user)
    
  end
  
  def logout
    cookies.delete(:echidna_cookie)
    session[:user] = nil  
    session[:user_id] = nil
    render :text => 'logged out'
  end
  
  #cookies[:gwap2_cookie] = {:value => user.email,
  #  :expires => 1000.days.from_now }
  
  
  def has_been_imported_already
    existing = Condition.find_by_sql(["select * from conditions where sbeams_project_id = ? and sbeams_timestamp = ?",
      params[:projectId].to_i, params[:dateDir]])
    render :text => (existing.empty?) ? "false" : "true"
  end
  
  
  def get_filtered_conditions
    if params[:result_type] == 'all'
      conds = Condition.find :all, :order => 'id'
    elsif params['result_type'] == 'ungrouped'
      conds = Condition.find_by_sql "select * from conditions where id not in (select distinct condition_id from condition_groupings)"
    elsif params['result_type'] == 'grouped'
      conds = Condition.find_by_sql "select * from conditions where id in (select distinct condition_id from condition_groupings)"
    #elsif params['result_type'] == 'sharedbyothers'
    end

    sorted_conds = sort_conditions_for_time_series(conds)
    headers['Content-type'] = 'text/plain'
    
    sorted_conds = Condition.populate_num_groups(sorted_conds)
    render :text => sorted_conds.to_json(:methods => :num_groups) 
    #render :text => sorted_conds.to_json() 


  end
  
  def remove_conditions_from_group
    ids_to_remove = ActiveSupport::JSON.decode(params[:ids_to_remove])
    records_to_remove = ConditionGrouping.find_by_sql([\
      "select id from condition_groupings where condition_group_id = ? and condition_id in (?)",
      params[:group_id],ids_to_remove]).map{|i|i.id}
    ConditionGrouping.delete(records_to_remove)
    render :text => "ok"
  end
 
  # todo rename
  def search_conditions
    #render :text => "hi"
    #return false if true
    puts "in main/search_conditions"
    search = ActiveSupport::JSON.decode(params[:search])
    ids = Condition.find_by_sql(["select distinct condition_id from search_terms where word in (?)", search]).map{|i|i.condition_id}
    results = Condition.find_by_sql(["select * from conditions where id in (?)",ids])
    
    groups = get_groups_for_conditions(results)
    if (groups.empty?)
      render :text => "none" and return false
    else
      ret = []
      groups.each do |g|
        h = g.attributes
        h['num_results'] = g.num_results
        ret << {"condition_group" => h}
      end
      render :text => ret.to_json
      #render :text => groups.to_json(:methods => :ungrouped_ids)
    end
    
    #sorted_conds = sort_conditions_for_time_series(results)
    #sorted_conds = Condition.populate_num_groups(sorted_conds)
    #if (sorted_conds.empty?)
    #  render :text => "none" and return false
    #else
    #  render :text => sorted_conds.to_json(:methods => :num_groups) and return false
    #end
  end
  
  def get_all_conditions
     conds = Condition.find :all, :order => 'id'
    sorted_conds = sort_conditions_for_time_series(conds)
    headers['Content-type'] = 'text/plain'
    sql = "select "
    sorted_conds = Condition.populate_num_groups(sorted_conds)
    #render :text => sorted_conds.to_json() 
    render :text => sorted_conds.to_json(:methods => :num_groups) 
  end
  
  def check_if_group_exists
    group = ConditionGroup.find_by_name params[:group_name]
    render :text => (not group.nil?)
  end
  
  def create_new_group
    ids = ActiveSupport::JSON.decode params[:ids]
    group = ConditionGroup.new(:name => params[:name])
    begin
      ConditionGroup.transaction do
        group.save
        ids.each_with_index {|i,index|ConditionGrouping.new(:condition_id => i, :condition_group_id => group.id, :sequence => index +1).save}
        render :text => group.id
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
  end
  
  def get_all_groups
    groups = ConditionGroup.find :all, :order => 'name'
    ret = []
    groups.each do |g|
      h = g.attributes
      h['num_results'] = g.num_results
      ret << {"condition_group" => h}
    end
    render :text => ret.to_json # todo find out how to run the AR::B version of to_json
  end
  
  def get_conditions_for_group
    conds = find_conditions_for_group(params[:group_id])
      render :text => conds.to_json
  end
  
  def reorder_group
    conds = Condition.find_by_sql(\
      ["select * from conditions where id in (select condition_id from condition_groupings where condition_group_id = ? order by sequence)",
      params[:group_id]])
    sequence = ActiveSupport::JSON.decode(params[:ids])
    begin
      ConditionGrouping.transaction do
        sequence.each_with_index do |s,index|
          #logger.debug "s = #{s}"
          item = ConditionGrouping.find_by_condition_id_and_condition_group_id(s,params[:group_id])
          #logger.info "old sequence: #{item.sequence} new sequence: #{index+1}"
          item.sequence = (index+1)
          item.save
          #logger.info "after save, sequence: #{item.sequence}"
        end
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    render :text => "ok"#{}"#{params[:group_id]} :: #{params[:ids]} old order: #{conds.map{|i|i.id}.join(",")}"
    
  end

  def add_conditions_to_existing_group
    ids = ActiveSupport::JSON.decode(params[:ids])
    existing = ConditionGrouping.find_by_sql(["select * from condition_groupings where condition_id in (?) and condition_group_id = ?",
      ids,params['group_id'].to_i])
    max_seq = ConditionGrouping.find_by_sql(["select count(id) as result from condition_groupings where condition_group_id = ?",params[:group_id].to_i]).first().result().to_i
    max_seq += 1
      
    result = 'ok'
    result = 'warning' unless existing.empty?
    begin
      ConditionGrouping.transaction do
        ids.each do |id|
          already = existing.find{|i|i.condition_id == id}
          next unless already.nil?
          cg = ConditionGrouping.new(:sequence => max_seq, :condition_group_id => params[:group_id], :condition_id => id)
          cg.save
          max_seq += 1
        end
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    render :text => result
  end

  def get_groups_for_condition
    groups = \
      ConditionGroup.find_by_sql(\
      ["select * from condition_groups where id in (select distinct condition_group_id from condition_groupings where condition_id = ?) order by name",
      params[:condition_id]])
    render :text => groups.to_json
  end
  
  def get_condition_detail # seems like species should be an observation, not a column in conditions
    cond = Condition.find(params[:condition_id])
    result = {}
    if (cond.name_parseable?)
      result = cond.parse_name
    else
      result = cond.get_obs();
    end
    result['Species'] = cond.species.name
    render :text => result.to_json
    
    
  end
  
  def get_relationship_types
    render :text => RelationshipType.find(:all, :order => 'name').to_json
  end
  
  def get_data #todo - make it work for location-based data as well
    
    cond_ids = Condition.find_by_sql(["select condition_id from condition_groupings where condition_group_id = ? order by sequence",
      params[:group_id]]).map{|i|i.condition_id}
  
    data = get_matrix_data(cond_ids,params[:data_type])

    #    respond_to do |format|
    #      format.xml {render :text => DataOutputHelper.as_matrix(data)}
    #      format.text {render :text => DataOutputHelper.as_matrix(data)}
    #    end
    headers['Content-type'] = 'text/plain'
    render :text => as_json(data)
  
  
  end
  
  def get_data_for_conditions
    cond_ids = params[:condition_ids].split(",")
    data = get_matrix_data(cond_ids,params[:data_type])

    headers['Content-type'] = 'text/plain'
    render :text => as_json(data)
    
  end
  
  
  def get_data_for_groups
    group_ids = params[:group_ids].split(",")
    cond_ids = []
    for group_id in group_ids
      cond_ids += ConditionGrouping.find_by_sql(["select condition_id from condition_groupings where condition_group_id = ? order by sequence",group_id])
    end
    data = get_matrix_data(cond_ids.map{|i|i.condition_id},params[:data_type])
    render :text => as_json(data)
  end
  
  def get_data_for_group
    data = get_matrix_data_for_group(params[:group_id],params[:data_type])
    headers['Content-type'] = 'text/plain'
    render :text => as_json(data)
  end
  
  def add_new_relationship_type
    r = RelationshipType.new(:name => params[:name], :inverse => params[:inverse])
    r.save
    render :text => RelationshipType.find(:all, :order => 'name').to_json
  end

  def create_new_relationship
    r = Relationship.new(:relationship_type_id => params[:relationship_type_id], :group1 => params[:group1], :group2 => params[:group2])
    existing = Relationship.find(:first, :conditions => ["relationship_type_id = ? and group1 = ? and group2 = ?", r.relationship_type_id, r.group1, r.group2])
    if (existing.nil?)
      r.save
      render :text => "ok" and return false
    else
      render :text => "duplicate"
    end
  end
  
  def get_related_groups
    group_id = params[:group_id].to_i
    render :text => find_related_groups(group_id).to_json(:methods => [:relationship,:relationship_id])
  end
  
  def get_auto_completion_items
#    res = Condition.find(:all).map{|i|i.name}
#    res += ConditionGroup.find(:all).map{|i|i.name}
    res = SearchTerm.find(:all).map{|i|i.word}
    res.sort!
    res.uniq!
  
    render :text => res.to_json
  end
  
  def delete_relationship
    Relationship.delete(params[:relationship_id])
    render :text => find_related_groups(params[:group_id].to_i).to_json
  end
  
  def rename_group
    group = ConditionGroup.find(params[:group_id])
    group.name = params[:new_name]
    group.save
    render :text => "ok"
  end
  
  def delete_group
    begin
      ConditionGroup.transaction do
        relationships_to_delete = Relationship.find_by_sql(["select id from relationships where group1 = ? or group2 = ?",
          params[:group_id],params[:group_id]]).map{|i|i.id}
        Relationship.delete(relationships_to_delete)
        ConditionGroup.delete(params[:group_id])
      end
      render :text => "ok"
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
  end
  
  def testmail
    u = User.new(:email => "dtenenbaum@systemsbiology.org")
    UserMailer.deliver_register(u, {:secret_word => "zizzy"})
    render :text => "ok"
  end
  
  def is_duplicate_email
    exists = User.find_by_email(params[:email])
    result = (exists.nil?) ? "no" : "yes"
    render :text => result
  end
  
  def register
    u = User.new(:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email],
     :password => params[:password], :last_login_date => Time.now, :validated => false)
    u.save
    
    
    # send the email
    token = "#{u.email}~~~#{SECRET_SALT}"
    secure = Password::update(token)
    url = url_for(:action => nil, :email => u.email, :token => secure)
    UserMailer.deliver_register(u, {:url => url, :user => u})
    
    puts "url = #{url}"
    render :text => "ok"
  end

  def request_password_refresh
    u = User.find_by_email(params[:email])
    render :text => "no such account" and return false if u.nil?
    token = "#{u.email}~~~#{SECRET_SALT}"
    secure = Password::update(token)
    url = url_for(:action => nil, :email => u.email, :token => secure, :change_password => "true")
    
    UserMailer.deliver_password_refresh(u, {:url => url, :user => u})
    render :text => "ok"
  end
  
  def get_knockout_names
    sql = "select distinct gene from knockouts where gene != 'wild type' order by gene"
    res = Knockout.find_by_sql([sql]).map{|i|i.gene}
    render :text => res.to_json
  end
  
  def get_env_pert_names
    sql = "select distinct perturbation from environmental_perturbations order by perturbation"
    res = EnvironmentalPerturbation.find_by_sql([sql]).map{|i|i.perturbation}
    render :text => res.to_json
  end
  
  def structured_search
    puts "STRUCTURED SEARCH params:"
    pp params
    env_perts = params[:env_perts]
    knockouts = params[:knockouts]
    include_related_results = (params[:include_related_results] == "true") ? true : false
    refine = params.has_key?(:currently_displayed_ids)
    if (refine)
      currently_displayed_ids = ActiveSupport::JSON.decode(params[:currently_displayed_ids])
      id_map = {}
      for id in currently_displayed_ids
        id_map[id.to_i] = 1
      end
    end
    conds = []
    if (params.has_key?(:env_perts) and !params.has_key?(:knockouts))
      conds =  Condition.find_by_sql(["select * from conditions where id in (select condition_id from environmental_perturbation_associations where environmental_perturbation_id in (select id from environmental_perturbations where perturbation = ?))",params[:env_perts]])
    elsif (params.has_key?(:knockouts) and !params.has_key?(:env_perts))
      conds = Condition.find_by_sql(["select * from conditions where id in (select condition_id from knockout_associations where knockout_id in (select id from knockouts where gene = ?))", params[:knockouts]])
    elsif (params.has_key?(:knockouts) and params.has_key?(:env_perts))
        conds = Condition.find_by_sql(["select * from conditions where id in (select condition_id from knockout_associations where knockout_id in (select id from knockouts where gene = ?))  and id in  (select condition_id from environmental_perturbation_associations where environmental_perturbation_id in (select id from environmental_perturbations where perturbation = ?))", params[:knockouts], params[:env_perts]])
    end
    
    if refine
      refined = []
      for cond in conds
        refined.push cond if id_map.has_key?(cond.id)
      end
      conds = refined
    end
    
    
    if (include_related_results)
      group_ids = ConditionGrouping.find_by_sql(["select distinct condition_group_id from condition_groupings where condition_id in (?)",
        conds.map{|i|i.id}.join(",")])
      related_groups = []
      for group_id in group_ids
        related_groups += find_related_groups(group_id)
      end
      
      related_conds = []
      for group in related_groups
        related_conds += find_conditions_for_group(group.id)
      end
      
      tmp = conds + related_conds
      
      conds = tmp.uniq
      
      # find group ids
      # find related groups
      # find conds from those
      # merge them with conds
    end
    
    
    groups = get_groups_for_conditions(conds)
    if (groups.empty?)
      render :text => "none" and return false
    else
      ret = []
      groups.each do |g|
        h = g.attributes
        h['num_results'] = g.num_results
        ret << {"condition_group" => h}
      end
      
      
      
      #render :text => groups.to_json(:methods => :ungrouped_ids)
      render :text => ret.to_json
    end
    
    
    #sorted_conds = sort_conditions_for_time_series(conds)
    
    #sorted_conds = Condition.populate_num_groups(sorted_conds)
    
    
    
    
    #if (sorted_conds.empty?)
    #  puts "sorted conds: no match"
    #  render :text => "none" and return false
    #else
    #  puts "structured search returning #{sorted_conds.size} results"
    #  render :text => sorted_conds.to_json(:methods => :num_groups) and return false
    #end
    

  end
  
  def save_search
    puts "in save_search, input is:\n#{params[:search]}"
    search = ActiveSupport::JSON.decode params[:search]
    # todo - determine whether this is a duplicate
    existing = UserSearch.find_by_name_and_user_id(search['name'], session[:user_id])
    render :text => "duplicate" and return false unless existing.nil?
    free_text_search_terms = (search['isStructured']) ? nil : search['freeTextSearch'].join("~~")
    begin
      UserSearch.transaction do
        user_search = UserSearch.new(:name => search['name'], :is_structured => search['isStructured'], :user_id => session[:user_id],
          :free_text_search_terms => free_text_search_terms)
        user_search.save
        if (search['isStructured'])
          search['subSearches'].each_with_index do |sub_search, i|
            ss = SubSearch.new(:user_search_id => user_search.id, 
              :environmental_perturbation => sub_search['envPert'],
              :knockout => sub_search['knockout'],
              :include_related => search['includeRelated'],
              :refine => search['refine'],
              :last_results_option_selected => search['lastResultsOptionSelected'],
              :sequence => i+1)
            ss.save
          end
        end
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace
    end
    
    
    render :text => "ok"
  end
  
  def test
    render :text => "ok"
  end
  
  def get_timestamp_from_search_terms
    render :text => SearchTerm.find_by_sql("select max(int_timestamp) as result from search_terms").first.result
  end
  
  def get_saved_searches
    results = UserSearch.find_all_by_user_id session[:user_id], :order => 'name', :include => :sub_searches
    pp results
    render :text => results.to_json(:methods => :sub_searches)
  end
  
  def run_saved_search
    canned_search = ActiveSupport::JSON.decode params[:canned_search]
    puts "canned search:"
    pp canned_search
    
    # determine depth of search
    # canonical view
    
    render :text => "ok"
  end

  def get_condition_info_for_ids
    ids = ActiveSupport::JSON::decode params[:cond_ids]
    conds = Condition.find_by_sql(["select * from conditions where id in (?)",ids])
    render :text => conds.to_json
  end
  
  
  def get_matrices_for_firegoose
    #qs = query_string.gsub(/&amp;/,"&")
    data_type = ""
    if (params["amp;data_type"])
      data_type = params["amp;data_type"]
    elsif (params["data_type"])
      data_type = params["data_type"]
    end


    
    
    cond_ids = []
    data = ''
    if (params[:group_ids])
      group_ids = params[:group_ids].split(",")
      cond_ids = []
      conds = []
      for group_id in group_ids
        conds += ConditionGrouping.find_by_sql(["select condition_id from condition_groupings where condition_group_id = ? order by sequence",group_id])
      end
      cond_ids = conds.map{|i|i.condition_id}
    elsif (params[:condition_ids])
      cond_ids = params[:condition_ids].split(",")
    end

    #render :text => "ok" and return false if true


    data = get_matrix_data(cond_ids,data_type)

    headers['Content-type'] = 'text/plain'
    
    render :text => as_matrix(data)
  end
  
end
