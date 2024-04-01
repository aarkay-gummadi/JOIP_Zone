Configuring the sonarcloud and jfrog artifactory for projects
--------------------------------------------------------------

* Firstly take instance type as t2.large and take 2 instances
    * In first instance we have to install the openjdk-17-jdk and maven and jenkins(Long Term Support release)[refer here](https://www.jenkins.io/doc/book/installing/linux/#long-term-support-release) for the LTS release official docs.
![preview](Images/sonar1.png)
![preview](Images/sonar2.png)
![preview](Images/sonar3.png)
![preview](Images/sonar4.png)
![preview](Images/sonar5.png)
* Lets us wait for instance state is running and status checks are 2/2 checks passed
```
sudo apt update
sudo apt install openjdk-17-jdk maven -y
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update
sudo apt install jenkins

```
![preview](Images/sonar6.png)

    * next second instance we have to install opnejdk-8-jdk and openjdk-11-jdk and maven

```
sudo apt update
sudo apt install openjdk-8-jdk openjdk-11-jdk maven -y
```
![preview](Images/sonar7.png)

* And then will run commad `cat /etc/passwd` it will show the list of all user and in that users we have a jenkins user created
![preview](Images/sonar8.png)

* Add jenkins user to sudoers the command is `sudo visudo`
![preview](Images/sonar9.png)
* Take the controller public ip address and open browser and add new tab and run the command `http://35.90.104.120:8080`
![preview](Images/sonar10.png)
![preview](Images/sonar11.png)
![preview](Images/sonar12.png)
![preview](Images/sonar13.png)
![preview](Images/sonar14.png)
* Its getting started to install required plugins
* Fill the above fields and click on save and continue
![preview](Images/sonar15.png)
* Next without doing anything just click on save and finish
![preview](Images/sonar16.png)
![preview](Images/sonar17.png)
![preview](Images/sonar18.png)
* In that Global Tool configuration a little bit scroll down you see the JDK and add java versions and home path of the java 
![preview](Images/sonar19.png)
![preview](Images/sonar20.png)
![preview](Images/sonar21.png)
![preview](Images/sonar22.png)
![preview](Images/sonar23.png)
![preview](Images/sonar24.png)
![preview](Images/sonar25.png)
![preview](Images/sonar26.png)
![preview](Images/sonar27.png)
![preview](Images/sonar28.png)
![preview](Images/sonar29.png)
![preview](Images/sonar30.png)
![preview](Images/sonar31.png)
* And add one more project called FreeStyle
![preview](Images/sonar32.png)
* Go to Manage Jenkins => Manage credentials
![preview](Images/sonar33.png)
![preview](Images/sonar34.png)
![preview](Images/sonar35.png)
* Take the jenkins nodes private key and paste it on 'New credentials => ID'
![preview](Images/sonar36.png)
![preview](Images/sonar37.png)
![preview](Images/sonar38.png)
![preview](Images/sonar39.png)
![preview](Images/sonar40.png)
![preview](Images/sonar41.png)
![preview](Images/sonar42.png)
![preview](Images/sonar43.png)
![preview](Images/sonar44.png)
![preview](Images/sonar45.png)

```
 ls
cp jenkins.pem /tmp/
sudo chown jenkins:jenkins /tmp/jenkins.pem
sudo chmod 400 /tmp/jenkins.pem
ls -al /tmp/ | grep jenkins.pem
sudo -i
ls
ssh -i /tmp/jenkins.pem ubuntu@172.31.12.221
cd ~/.ssh/
ls
```

![preview](Images/sonar46.png)
![preview](Images/sonar47.png)
![preview](Images/sonar48.png)
![preview](Images/sonar49.png)
![preview](Images/sonar50.png)
![preview](Images/sonar51.png)
![preview](Images/sonar52.png)
* Add one more Declaratice project called springpetclinic-Declarative
![preview](Images/sonar53.png)
![preview](Images/sonar54.png)
* It was trying to tell that jdk version was not present
![preview](Images/sonar55.png)


* Execute in jenkins node 
```
mvn --version
sudo apt install openjdk-17-jdk -y
export PATH="/usr/lib/jvm/java-17-openjdk-amd64/bin:$PATH"
mvn --version
```
![preview](Images/sonar57.png)
![preview](Images/sonar58.png)
![preview](Images/sonar59.png)
![preview](Images/sonar60.png)
![preview](Images/sonar61.png)
* Its fail the build because of that the java is not present correctly
![preview](Images/sonar63.png)
![preview](Images/sonar62.png)
![preview](Images/sonar64.png)
* There is a some setting problem to solve it
![preview](Images/sonar65.png)
![preview](Images/sonar66.png)
* This token for Created Jfrog credential
![preview](Images/sonar67.png)
![Alt text](image-2.png)
![Alt text](image-3.png)
* This token for Created SonarQube credential
![Alt text](image.png)
![Alt text](image-4.png)

* Added the maven path in Global Tool Configuration
![Alt text](image-1.png)
![Alt text](image-5.png)
![Alt text](image-6.png)
![Alt text](image-7.png)
![Alt text](image-8.png)
[refer here](https://github.com/qtrajkumarmarch23/spring-petclinic/blob/main/Jenkinsfile) for the changes in jenkinsfile to added the sonarqube steps


```Jenkinsfile
pipeline {
    agent { label 'JDK_8' }
    triggers { pollSCM ('* * * * *') }
    parameters {
        choice(name: 'MAVEN_GOAL', choices: ['package', 'install', 'clean'], description: 'MAVEN_GOAL')
    }
    stages {
        stage('vcs') {
            steps {
                git url: 'https://github.com/qtrajkumarmarch23/spring-petclinic.git',
                    branch: 'main'
            }
        }
        stage('package') {
            tools {
                jdk 'JDK_17'
            }
            steps {
                sh "mvn ${params.MAVEN_GOAL}"
            }
        }
        stage('sonar analysis') {
            steps {
                // performing sonarqube analysis with "withSonarQubeENV(<Name of Server configured in Jenkins>)"
                withSonarQubeEnv('SONAR_TOKEN') {
                    sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=springpetclinic07_sonar -Dsonar.organization=springpetclinic07'
                }
            }
        }
        stage('post build') {
            steps {
                archiveArtifacts artifacts: '**/target/spring-petclinic-3.0.0-SNAPSHOT.jar',
                                 onlyIfSuccessful: true
                junit testResults: '**/surefire-reports/TEST-*.xml'                 
            }
        }
    }
}
```

![Alt text](image-9.png)


* Jenkinsfile for jfrog

```Jenkinsfile
pipeline {
    agent { label 'JDK_8' }
    triggers { pollSCM ('* * * * *') }
    parameters {
        choice(name: 'MAVEN_GOAL', choices: ['package', 'install', 'clean'], description: 'MAVEN_GOAL')
    }
    stages {
        stage('vcs') {
            steps {
                git url: 'https://github.com/qtrajkumarmarch23/spring-petclinic.git',
                    branch: 'main'
            }
        }
        stage('package') {
            tools {
                jdk 'JDK_17'
            }
            steps {
                sh "mvn ${params.MAVEN_GOAL}"
            }
        }
        stage ('Artifactory configuration') {
            steps {
                rtServer (
                    id: "ARTIFACTORY_SERVER",
                    url: 'https://qtkhajamarch23.jfrog.io/artifactory',
                    credentialsId: 'JFROG_CLOUD_ADMIN'
                )

                rtMavenDeployer (
                    id: "MAVEN_DEPLOYER",
                    serverId: "ARTIFACTORY_SERVER",
                    releaseRepo: 'libs-release',
                    snapshotRepo: 'libs-snapshot'
                )

                rtMavenResolver (
                    id: "MAVEN_RESOLVER",
                    serverId: "ARTIFACTORY_SERVER",
                    releaseRepo: 'libs-release',
                    snapshotRepo: 'libs-snapshot'
                )
            }
        }
        stage('package') {
            tools {
                jdk 'JDK_17'
            }
            steps {
                rtMavenRun (
                    tool: 'MAVEN_CLOUD_TOKEN',
                    pom: 'pom.xml',
                    goals: 'clean install',
                    deployerId: "MAVEN_DEPLOYER"
                    
                )
                rtPublishBuildInfo (
                    serverId: "ARTIFACTORY_SERVER"
                )
                //sh "mvn ${params.MAVEN_GOAL}"
            }
        }
        stage('sonar analysis') {
            steps {
                // performing sonarqube analysis with "withSonarQubeENV(<Name of Server configured in Jenkins>)"
                withSonarQubeEnv('SONAR_TOKEN') {
                    sh 'mvn verify org.sonarsource.scanner.maven:sonar-maven-plugin:sonar -Dsonar.projectKey=springpetclinic07_sonar -Dsonar.organization=springpetclinic07'
                }
            }
        }
        stage('post build') {
            steps {
                archiveArtifacts artifacts: '**/target/spring-petclinic-3.0.0-SNAPSHOT.jar',
                                 onlyIfSuccessful: true
                junit testResults: '**/surefire-reports/TEST-*.xml'                 
            }
        }
    }
}
```
* Added the jfrog to the jenkinsfile
![Alt text](image-10.png)
* Jfrog => Builds
![Alt text](image-11.png)



* This is for Maven project for FreeStyle
![preview](Images/sonar79.png)
* This is for MutliBranch Project fo Declarative with defferent branches
![preview](Images/sonar80.png)
* One thing will fail in the main branch, because of in the Jenkinsfile we didn't change the steps of jfrog and sonarqube, that things are remove the main branch also will be success.
![preview](Images/sonar81.png)
![preview](Images/sonar82.png)
![preview](Images/sonar83.png)
![preview](Images/sonar84.png)
* Some changes in the Jenkinsfile of main branch
![preview](Images/sonar85.png)
* The main branch we have a project will be fail, we have a solution for that.
* It will starts working on the changes in the main branch Jenkinsfile
![preview](Images/sonar86.png)
![preview](Images/sonar87.png)
![preview](Images/sonar88.png)
![preview]
![preview]
![preview]

![preview]
![preview]
![preview]
![preview]
![preview]
![preview]
![preview]
![preview]
![preview]
![preview]


