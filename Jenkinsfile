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
                echo '[hosts_to_add_key]' >> aws_hosts
                echo $(terraform -chdir=./dev/compute/applications/simplewebapp/ output -json simplewebapp-appserver-public-ip) | awk -F'"' '{print $2," ansible_user=ubuntu"}'>> aws_hosts
                '''
                }
            }
        }
          stage('Accept Terraform Destroy?'){
             input {
                message "Do you want to delete this infrastructure?"
                ok "Apply Plan"
            }
            steps {
                echo "Destroy Accepted"
            }
            
        }
         stage('Terraform Destroy'){
        
            steps{
                withAWS(credentials: 'Jenkins-AWS') {
                    sh 'terraform -chdir=./dev/compute/applications/simplewebapp/ destroy --auto-approve'
                }
            }
        }

    }
    
}