{async, strip-trailing} = require './test-util'
exec = require \child_process .exec
require! util

describe 'bin/jenkins' (,) ->
  it 'displays help' (done) ->
    (,, stderr) <- exec './node_modules/.bin/lsc ./src/index.ls'
    stderr := strip-trailing stderr

    help =
      """
      Usage: jenkins <command> [options]

      Commands:
        tail         read build logs
        configure    open configure view in browser for a job
        setup        interactively configure jenkins base url\n\n
      """

    eq help, stderr
    done!
