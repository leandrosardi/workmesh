# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'workmesh-update-config',
  :commands => [
    { 
        # back up old configuration file
        # upload configuration file from local working directory to remote server
        :command => "
            cd ~/code/%workmesh_service%; 
            mv ./config.rb ./config.%timestamp%.rb;
            echo \"%config_rb_content%\" > ./config.rb;
        ",
        #:matches => [ /^$/, /mv: cannot stat '\.\/config.rb': No such file or directory/ ],
        #:nomatches => [ { :nomatch => /.+/, :error_description => 'No output expected.' } ],
        :sudo => false,
    },
  ],
});
