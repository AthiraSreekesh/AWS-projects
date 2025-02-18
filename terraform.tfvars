region             = "ap-south-1"
project_name       = "LAMP"
environment        = "Development"
owner              = "Athira"
names              = ["bastion", "webserver", "db"]
webserver_sg_ports = ["80", "443"]
db_sg_ports        = ["3306"] 