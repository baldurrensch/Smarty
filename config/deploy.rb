set :deploy_via, :remote_cache
set :application, "livehelp"
set :scm, :git
set :default_stage, "dev"
set :stages, %w{dev qa production}
require 'capistrano/ext/multistage'

after "multistage:ensure"  do
	set :repository, "git:Smarty.git"
	set :deployed, "Branch master" 
	if variables.include?(:branch)
		set :deployed, "Branch #{branch}"
	end
	if variables.include?(:tag)
		set :deployed, "Branch #{branch}"
	end
end

namespace :deploy do
	[:restart].each do |default_task|
		task default_task do 
			# squash unused tasks
		end
	end
end

namespace :deploy do
	task :finalize_update do
		run <<EOF
			rm -f #{release_path}/config/deploy.rb &&
			rm -rf #{release_path}/config/deploy &&
			rm -rf #{release_path}/.git &&
			rm -rf #{release_path}/development &&
			rm -rf #{release_path}/documentation &&
			rm -rf #{release_path}/distribution/COPYING.lib &&
			rm -rf #{release_path}/distribution/README &&
			rm -rf #{release_path}/distribution/SMARTY* &&
			rm -rf #{release_path}/distribution/change_log.txt &&
			rm -rf #{release_path}/distribution/demo &&

COPYING.lib  README  SMARTY2_BC_NOTES  SMARTY_2_BC_NOTES.txt  SMARTY_3.0_BC_NOTES.txt  SMARTY_3.1_NOTES.txt  change_log.txt  demo/  libs/

			echo \"#{deployed} has been deployed to #{dserver} at #{Time.now}\" > #{release_path}/REVISION
EOF
		system( "echo \"#{deployed} has been deployed to #{dserver} at #{Time.now}\" | mailx -s \"Tag deployed at #{Time.now}\" onpdeployment@opensoftdev.com" );
	end

end
