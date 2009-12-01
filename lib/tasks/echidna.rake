namespace "echidna" do
  desc 'deploy client source files'
  task :deploy_client do
    puts "in deploy_client"
    cp_r 'client/bin-debug/.', 'public'
    cp 'public/echidna.html', 'public/index.html'
    #ln_s 'public/index.html', 'public/echidna.html'
  end
end