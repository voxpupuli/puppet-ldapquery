pipeline {
  agent any

  environment {
    PATH = "$PATH:~/.rbenv/bin"
  }

  stages {
    stage('bundle') {
      steps {
        sh '. .env.sh && printenv && bundle'
      }
    }
    stage('rake test') {
      steps {
        sh '. .env.sh && bundle exec rake test'
      }
    }
    stage('clean') {
      steps {
        sh '. .env.sh && bundle exec rake clean'
      }
    }

    if (env.BRANCH_NAME == "master") {
      stage('build') {
        steps {
          sh '. .env.sh && bundle exec rake build'
        }
      }
    }
  }
}
