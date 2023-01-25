# APEX-RAS-Cloud
APEX  RAS Demo for Oracle Cloud Free Tier

This will install the RAS Demo code on Oracle Cloud Free Tier and sample  APEX app.

# INSTALLATION

Overview

1. create system
1. install schema with RAS Rules
1. install APEX APP
1. create APEX  users

##  Create System

In Oracle Cloud Management (web site)

1. create atp free  tier database
   - note ADMIN  password
1. get wallet
   - note location of wallet
   - note password for wallet
1. create APEX workspace
   - note workspace name
   - note password
   - note URL
1. (opt)create DB Connnection for ADMIN in SQL Developer
1. (opt)create DB Connnection for HR in SQL Developer

## Create HR Schema

1. Connect to the DB as HR (This was tested with SQL Developer 20.1)
1. run `02_hr_install.sql`
   - note - should have zero errors
 1. `grant db_emp to *apex workspace*`

## Install APEX App

1. log into your APEX Workspace as your workspace administrator (refer to the URL you recorded)
1. install the apex app `03_admin_install_apex_app`
   -  note  there should be no errors
1. do not log out just yet

## Create APEX Users

1. you should still be logged in to your APEX Workspace
1. create the user `daustin`  with password  `Change0nInstall`
1. create the user `smavris`  with password  `Change0nInstall`

## Test App

URL should be in this format:

`https://*db_instance*.*region*.oracecloud.com/ords/f?p=hr_demo`
