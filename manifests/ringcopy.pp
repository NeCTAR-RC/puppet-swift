define swift::ringcopy()
{
    $cluster_name = hiera('swift::cluster_name')

    file {"/etc/swift/${name}.ring.gz":
          ensure => file,
          owner => swift,
          group => swift,
          source => "puppet:///modules/swift/ring_file/${cluster_name}/${name}.ring.gz",
          }

}
