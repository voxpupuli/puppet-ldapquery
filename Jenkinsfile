pipeline {
  agent any

  environment {
    PATH = "$PATH:~/.rbenv/bin"
  }

  stages {
    stage('bundle') {
      steps {
        sh '. .env.sh && bundle'
      }
    }
    stage('rake test') {
      steps {
        sh '. .env.sh && bundle exec rake test'
      }
    }
    stage('module:build') {
      steps {
        sh '. .env.sh && bundle exec rake module:build'
      }
    }
  }
}
