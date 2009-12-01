namespace "echidna" do
  desc 'deploy client source files'
  task :deploy_client do
    puts "in deploy_client"
    cp_r 'client/bin-debug/.', 'public'
    mv 'public/echidna.html', 'public/index.html'
  end
end