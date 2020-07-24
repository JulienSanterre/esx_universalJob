# Universal Job V1

## Requirements 

* [esx_service](https://github.com/ESX-ORG/esx_service)
* [esx_society](https://github.com/ESX-ORG/esx_society)
* [esx_billing](https://github.com/ESX-ORG/esx_billing)
* [es_extended](https://github.com/esx-framework/es_extended)
* [mysql-async](https://github.com/brouznouf/fivem-mysql-async)

## Installation 
* Import esx_universalJob.sql in your database
* Add this to your server.cfg
```
start esx_universalJob
``` 
## File Duplication
##### !!! if your config.jobname has a capital letter, your Mysql file must also include a capital letter !!!
##### For example if: Config.JobName = "Tabac" // Then in your mysql file: ('society_Tabac', 'Marlboro', 1)
This script has been designed to be able to be duplicated in order to add as many trades as you want. 
The procedure is as follows:
- Clone your file
- Modify the config.cfg file in order to configure your job as you wish
- Modify the mysql file in order to configure it for a new job
- Modify your Locales / fr file (or other languages)
- And start clone process in server.cfg

## Legal
License
esx_universalJob

Copyright (C) 2020-2023 JulienSanterre

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.
