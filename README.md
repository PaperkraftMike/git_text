# Git Text
## Have your GitHub issues texted to you using Twilio 

![sample text](http://imgur.com/xhOw5Ts)

1. Sign up for [Twilio](http://www.twilio.com/)

3. Make sure you have [Ruby](https://rvm.io/rvm/install) installed 

4. Set environmental variables for your `GITHUB_USERNAME` and `GITHUB_PASSWORD`

5. Set the environmental variable for your `TWILIO_ACCOUNT_SID` and `TWILIO_AUTH_TOKEN`


```
cat << EOF >> ~/.bash_profile
export GITHUB_USERNAME='yourgithubemail@youremailhost.com'
export GITHUB_PASSWORD='yourgithubpassword'
export TWILIO_ACCOUNT_SID='yourtwilioaccountsid'
export TWILIO_AUTH_TOKEN='yourtwilioauthtoken'
EOF

source ~/.bash_profile
```

6. Modify `git_text.yml` with a repo, user, filter, and assignee you'd like to print issue changes for.

7. Migrate the database:

    `rake db:migrate`

8. Run the script, `ruby git_print.rb`, to start getting texts every time an issue with that assignee is modified! The script must be running for this to work.


## Contributing

Forks and contributions are welcome! Bring them on! 

## Credits

Much thanks go out to the great [@zachfeldman](http://zfeldman.com/) and his [git_print](https://github.com/zachfeldman/git_print) for being my inspiration for this project. If you'd rather have your issues printed out onto sticky labels then make sure to check out his project. 



