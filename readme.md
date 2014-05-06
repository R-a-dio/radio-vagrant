## Setup
  1. Download [virtualbox](https://www.virtualbox.org/wiki/Downloads) and
      [vagrant](http://downloads.vagrantup.com/)
  2. Run `vagrant up` to start and configure the VM. This will need to download a
      ~300 MB file the first time you run it.
  3. Go to "localhost:8080" in your browser
      If port 8080 is in use by another program this will differ. Look for
      a line like
      `[default] Fixed port collision for 80 => 8080. Now on port 2200.`
      and substite the appropriate port.
  4. If everything went well you should see a new "radio_site" directory. This
      is a copy of the repo from Github
  5. When you are done working shut down the VM with `vagrant halt`


## Basic Usage
  - `vagrant up`        Boots and provisions VM according to Vagrantfile
  - `vagrant provision` Configures an already running VM
  - `vagrant ssh`       SSH into a running VM
  
  - `vagrant suspend` Saves the VM state allowing you to resume exactly where you left
       off, bypassing boot sequence. This will use extra disk space to save RAM but
       no longer uses RAM or CPU cycles
  - `vagrant resume`  Resumes a suspended VM
  - `vagrant halt`    Shuts down VM
  - `vagrant destroy` Deletes VM from disk


## Known bugs
  - Tables for 'radio' database are not created so you will need to create them yourself