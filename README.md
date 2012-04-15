# Vagrant boxes

![Vagrant logo](http://vagrantup.com/static/images/hippie.png)

### Requirements

* [Vagrant](http://vagrantup.com/docs/getting-started/index.html)
* [Veewee](https://github.com/jedi4ever/veewee)

### Available Boxes

* Drupal


### Build boxes

    vagrant basebox define your_name_box ubuntu-11.10-server-amd64
    vagrant basebox build your_name_box
    vagrant basebox validate your_name_box
    vagrant basebox export your_name_box

* To import it into vagrant type:    
vagrant box add 'your_name_box' 'your_name_box.box'

* To use it:    
    vagrant init 'your_name_box'    
    vagrant up    
    vagrant ssh