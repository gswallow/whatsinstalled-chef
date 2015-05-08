# Whichsapp-Chef

## Recipes

The deploy recipe installs the Whichsapp sinatra application and a single instance of etcd.

The agent recipe installs the Whichsapp agent and configures it to look for your apps' versions.

To configure the agent, pass in some attributes:

...
default_attributes(
  'whichsapp' => {
    'apps' => {
      'web' => '/var/www/apps/ascent-web/current',
      'compute_runner' => '/var/scripts/compute-runner/current'
    },
    'assays' => '/var/scripts/assays',
    'packages' => [
      'tokumx-clients',
      'tokumx-common',
      'indigo-compute-3.4.1',
      'indigo-compute-core-3.4.1',
      'referee'
    ]
  }
)
...
