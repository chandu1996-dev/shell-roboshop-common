#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-roboshop/mongodb.log
start_TIME=$(date +%s)
SCRIPT_DIR=$PWD # for absoulute path

MONGODB_HOST=mongo.born96.fun
MYSQL_HOST=mysql.born96.fun


mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

check_root(){
if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 # failure is other than 0
fi

}

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e  "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}


nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling the nodejs"

    dnf  module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enable the nodesjs"


    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "install the modesjs"

    npm install &>>$LOG_FILE
    VALIDATE $? "Install dependencies"

}

java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing Maven"
    mvn clean package &>>$LOG_FILE
    VALIDATE $? "Packing the application"
    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "Renaming the artifact"
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "Installing Python3"
    pip3 install -r requirements.txt &>>$LOG_FILE
    VALIDATE $? "Installing dependencies"
}


app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "Creating system user"
    else
        echo -e "User already exist ... $Y SKIPPING $N"
    fi

    mkdir -p /app  &>>$LOG_FILE    
    VALIDATE $? "creating a directory name as app"


    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip &>>$LOG_FILE
    VALIDATE $? "downlod the $app_name application"

    cd /app 
    VALIDATE $? "change directory"

    rm -rf /app/*
    VALIDATE $? "Removing existing code"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzip the code"
}

 systemd_setup(){

        cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service 
        VALIDATE $? "copying systemctl services"
        systemctl daemon-reload 
    }

app_restart(){

    systemctl restart $app_name
    VALIDATE $? "Restarting appname"
    }

print_total_time(){
    END_TIME=$(date +%s)

    TOTAL_TIME=$(($END_TIME - $start_TIME))
    echo -e "script excuted in : $Y $TOTAL_TIME seconds : $N"

}
