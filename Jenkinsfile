pipeline {
  agent any

  triggers { pollSCM('*/15 * * * *') }

  environment {
    PATH = "$PATH:~/.rbenv/bin"
  }

  stages {
    stage('test') {
      steps {
        sh '. .env.sh && printenv && bundle'
        sh '. .env.sh && bundle exec rake test'
      }
    }

    stage('build') {
      when {
        branch 'master'
      }

      steps {
        sh '. .env.sh && bundle exec rake clean'
        sh '. .env.sh && bundle exec rake build'

        sh '[ "$(git rev-list -n 1 $(git tag | tail -n 1 ))" == "$(git rev-list -n 1 HEAD)" ] && bundle exec rake publish pkg/*.tar.gz'
      }
    }
  }
}
