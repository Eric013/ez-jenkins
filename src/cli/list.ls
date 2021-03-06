{format-jobs-table, die, jobs-filter-by-str} = require '../utils'
require! '../api/list-jobs'
require! ramda: {identity, is-empty, filter, prop, pick, pick-by, prop-eq, keys, to-pairs, map, apply, complement, lens, head, tail, any-pass, is-nil}
debug = require '../debug' <| __filename

negate-if-false = (fn, bool) ->
  | not bool  => complement fn
  | otherwise => fn

head-lens = lens do
  head, (val, list) -> [val] ++ tail list

PREDICATES =
  building   : prop-eq \building, true
  successful : prop-eq \result, \SUCCESS
  failed     : prop-eq \result, \FAILURE
  recent     : (job) -> (Date.now! - job.timestamp) < 1000 * 60 * 10min

get-predicates = (argv) ->
  pick-by (complement is-nil), argv
  |> to-pairs . pick (keys PREDICATES), _
  |> map head-lens.map (prop _, PREDICATES)
  |> map apply negate-if-false

filter-by-predicates = (argv) ->
  ps = get-predicates argv
  switch
  | is-empty ps => identity
  | otherwise   => filter (any-pass ps)

cli-list = (argv) ->
  {__: input} = argv

  list-jobs!
    .then jobs-filter-by-str input
    .then filter-by-predicates argv
    .then (jobs) ->
      unless is-empty jobs
        console.log format-jobs-table jobs
      else
        console.error 'Nothing found with given parameters'
    .catch die

module.exports = cli-list
