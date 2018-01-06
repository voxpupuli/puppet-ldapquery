pipeline {
  agent any

  environment {
    PATH = "$PATH:$HOME/.rbenv/bin"
  }

  stages {
    stage('bundle') {
      steps {
        sh 'bundle'
      }
    }
    stage('rake test') {
      steps {
        sh 'bundle exec rake test'
      }
    }
    stage('module:build') {
      steps {
        sh 'bundle exec rake module:build'
      }
    }
  }
}
