# setup deploying rutines
BlackStack::Deployer::add_routine({
  :name => 'workmesh-update-source',
  :commands => [
    { 
        :command => 'mkdir ~/code;',
        :matches => [ /^$/i, /File exists/i ],
        :sudo => false,
    }, { 
        :command => 'mkdir -p ~/code/%workmesh_service%;',
        :matches => [ /^$/i, /File exists/i ],
        :sudo => false,
    }, { 
        :command => '
            cd ~/code/%workmesh_service%;
            rm -r ./*;
            git clone https://github.com/%workmesh_service% .;
        ',
        :matches => [ 
            /already exists and is not an empty directory/i,
            /Cloning into/i,
            /Resolving deltas\: 100\% \((\d)+\/(\d)+\), done\./i,
            /fatal\: destination path \'.+\' already exists and is not an empty directory\./i,
        ],
        :nomatches => [ # no output means success.
            { :nomatch => /error/i, :error_description => 'An Error Occurred' },
        ],
        :sudo => false,
    }, { 
        :command => '
            cd ~/code/%workmesh_service%;
            git fetch --all;
        ',
        :matches => [/\-> origin\//, /^Fetching origin$/],
        :nomatches => [ { :nomatch => /error/i, :error_description => 'An error ocurred.' } ],
        :sudo => false,
    }, { 
        :command => '
            cd ~/code/%workmesh_service%;
            git reset --hard origin/%git_branch%;
        ',
        :matches => /HEAD is now at/,
        :sudo => false,
    }, {
        # 
        :command => 'export RUBYLIB=~/code/%workmesh_service%;',
        :nomatches => [ 
            { :nomatch => /.+/i, :error_description => 'No output expected' },
        ],
        :sudo => false,
    }
  ],
});