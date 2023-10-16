pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        
    }
    stages{
        stage("Git Pull"){
            steps{
                git 'https://github.com/mpakeeru/Terraform-Lab.git' 
            }
        }
        stage('Terraform Init'){
            steps{
                withAWS(credentials: 'Jenkins-AWS') {
                    sh 'terraform -chdir=./dev/compute/applications/simplewebapp/ init'
                }
            }
        }
        stage('Terraform Apply'){
            steps{
                withAWS(credentials: 'Jenkins-AWS') {
                    sh 'terraform -chdir=./dev/compute/applications/simplewebapp/ apply --auto-approve'
                }
            }
        }
        stage('create aws-ansible-inventory'){
            steps {
                withAWS(credentials: 'Jenkins-AWS') {
                sh '''
                rm aws_hosts
                echo '[hosts_to_add_key]' >> aws_hosts
                echo $(terraform -chdir=./dev/compute/applications/simplewebapp/ output -json simplewebapp-appserver-public-ip) | awk -F'"' '{print $2," ansible_user=ubuntu"}'>> aws_hosts
                echo '[hosts_to_add_key:vars]'>>aws_hosts
                echo 'ansible_ssh_common_args="-o StrictHostKeyChecking=no"'>>aws_hosts
                '''
                }
            }
        }
        stage('wait EC2') {
            steps {
                sh '''
                cd dev/compute/applications/simplewebapp
                 aws ec2 wait instance-status-ok --region us-east-2 --instance-ids '$(terraform output -json ec2_id_test) | awk -F'"' '{print $2}''
                 '''
            }
        }
 
    }
 
    
}