#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
    VALIDATE $? "Adding Mongo repo"


    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "Installing mongodb" 

    systemctl enable mongod &>>$LOG_FILE
    VALIDATE $? "Enable the mongodb" 

    systemctl start mongod &>>$LOG_FILE
    VALIDATE $? "Start mongodb" 

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
    VALIDATE $? "Allow remote connections to mongodb"

    systemctl restart mongod 
    VALIDATE $? "Restart mongodb"

    print_total_time