# macOS solves

A reference for recurring macOS-specific instructions.

## R + Java

This depends on how Java was installed (package manager versus direct
download).

### 1. Terminal

``` bash
# Homebrew
brew info openjdk  
ls /opt/homebrew/opt/openjdk # expected installation location
brew --prefix openjdk # prints actual installation path (should be /opt/homebrew/opt/openjdk)
brew list | grep openjdk  

# Look for installations on the computer
/usr/libexec/java_home -V  # list all Java installations on the computer


# R CMD javareconf # R reconfiguration

export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home # output either from /usr/libexec/java_home -V or brew --prefix openjdk
sudo R CMD javareconf # R reconfiguration with admin privileges
```

### 2. R

``` r

# Then restart R session!
install.packages("rJava") # should work now
```

## R + gettext

You might receive an error related to gettext when installing an R
package.

### 1. Terminal

``` bash
# Install gettext with Homebrew
brew install gettext 

# Update Makevars
cd ~/.R
ls 
nano Makevars # or whatever text editor
```

In Makevars, add the following lines:

``` make
LDFLAGS += -L/opt/homebrew/opt/gettext/lib
CPPFLAGS += -I/opt/homebrew/opt/gettext/include
```

Save the update and close the text editor

### 2. R

``` r

# restart R and retry the installation
install.packages("iCantRememberTheNameOfThePackageIhadThisIssueWith")
```
