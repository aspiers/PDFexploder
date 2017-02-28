require 'open3'

module Command
  def self.run(cmd)
    out, err = '', ''
    success = Open3.popen3(*cmd) do |stdin, stdout, stderr, wait_thread|
      out = stdout.readlines().join('')
      err = stderr.readlines().join('')
      wait_thread.value.success?
    end
    return success, out, err
  end
end

