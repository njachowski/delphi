Setup:

Make sure R is installed along with the required libraries.

Check the paths and folders.

Install dbn (njachowski:db)
- remember to create db_config.py file
- add alias to bash profile: dbn

might need to install numpy: sudo pip install numpy
might need to install R:

add the following lines to /etc/apt/sources.list (need to sudo vi in to file to edit)
##latest/favorite R Cran mirror
deb http://cran.stat.nus.edu.sg/bin/linux/ubuntu precise/
-- you need to check what version of linux you're running first using>> lsb_release -a

then run>> sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 
then run>> sudo apt-get update
then run>> sudo apt-get r-base 
then run>> sudo apt-get r-base-dev
run>> vi ~/.Rprofile 
add the following lines to your .Rprofile:
options(repos=structure(c(CRAN="http://cran.stat.nus.edu.sg/“)))
.libPaths("/dir/to/store/libs”)
.First <- function(){
  .libPaths()
  cat("\n   Welcome to R!\n\n")
}
.Last <- function()  cat("\n   Goodbye!\n\n")

create aliases in bash_profile if they don't already exist:
alias delphi='python /home/analytics/nick/scripts/delphi/delphi.py'
alias dbn='python /home/analytics/nick/scripts/db/db.py'
