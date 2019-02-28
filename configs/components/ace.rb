component "bolt" do |pkg, settings, platform|
  pkg.load_from_json('configs/components/ace.json')

  pkg.build_requires 'rubygem-r10k'

  # We need to run r10k before building the gem.
  pkg.build do
    ["#{settings[:ruby_bindir]}/r10k puppetfile install --verbose" ]
  end

  pkg.build do
    ["#{settings[:host_gem]} build agentless-catalog-executor.gemspec"]
  end

  pkg.install do
    ["#{settings[:gem_install]} agentless-catalog-executor-*.gem"]
  end

  if platform.is_windows?
    # PowerShell Module
    pkg.add_source("file://resources/files/windows/PuppetBolt/PuppetBolt.psd1", sum: "f21e2bcfcb64da273e561e6066dce949")
    pkg.add_source("file://resources/files/windows/PuppetBolt/PuppetBolt.psm1", sum: "1ed17a54fd4df1032ea8d96c047ac623")

    pkg.directory "#{settings[:datadir]}/PowerShell/Modules/PuppetBolt"
    pkg.install_file "../PuppetBolt.psd1", "#{settings[:datadir]}/PowerShell/Modules/PuppetBolt/PuppetBolt.psd1"
    pkg.install_file "../PuppetBolt.psm1", "#{settings[:datadir]}/PowerShell/Modules/PuppetBolt/PuppetBolt.psm1"
  else
    pkg.add_source("file://resources/files/posix/ace_env_wrapper", sum: "644f069f275f44af277b20a2d0d279c6")
    ace_exe = File.join(settings[:link_bindir], 'ace')
    pkg.install_file "../ace_env_wrapper", ace_exe, mode: "0755"

    if platform.is_macos?
      pkg.add_source 'file://resources/files/paths.d/50-ace', sum: '4abf75aebbbfbbefc4fe0173c57ed0b2'
      pkg.install_file('../50-ace', '/etc/paths.d/50-ace')
    else
      pkg.link ace_exe, File.join(settings[:main_bin], 'agentless-catalog-executor')
    end
  end
end
