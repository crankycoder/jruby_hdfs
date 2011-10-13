if RUBY_PLATFORM =~ /java/
  require "java"
elsif $VERBOSE
  warn "only for use with JRuby"
end

if ENV["HADOOP_HOME"]
  HADOOP_HOME=ENV["HADOOP_HOME"]
  Dir["#{HADOOP_HOME}/hadoop-core*.jar","#{HADOOP_HOME}/lib/*.jar"].each  do |jar|
    require jar
  end
  
  $CLASSPATH << "#{HADOOP_HOME}/conf"
  
elsif $VERBOSE
  warn "HADOOP_HOME is not set!"
end

module Hdfs
  
  private
  
  class Fs
    import org.apache.hadoop.conf.Configuration
    import org.apache.hadoop.fs.FileSystem
    
    attr_reader :fs
    
    def initialize
      conf = Configuration.new
      @fs=FileSystem.get(conf)
      puts "HDFS has been created"
    end
    
    def exists?(path)
      @fs.exists(path.path)
    end
    
    def file?(path)
      @fs.isFile(path.path)
    end
    
    def open(path)
      @fs.open(path.path).to_io
    end
  end
  
  class Path
    import org.apache.hadoop.fs.Path
    
    attr_reader :path
    
    def initialize(p)
      @path=Path.new(p)
    end
    
  end
end

module Hdfs
  
  
  import org.apache.hadoop.fs.FSDataInputStream
  import org.apache.hadoop.fs.FSDataOutputStream
  
  @fs=Fs.new
  
  def self.fs
    @fs
  end
  
  class File
    
    def initialize(path)
      _path=Path.new(path)
      _fs=Hdfs::fs
      raise Errno::ENOENT, "File does not exist" unless _fs.exists?(_path)
      raise Errno::ENOENT, "File not a regular file" unless _fs.file?(_path)
      
      @stream = Hdfs::fs.open(_path);
    end
    
    def close
      @stream.close
    end
    
    def read
      @stream.read      
    end
    
    def closed?
      @stream.closed?
    end
    
    
  end
  
  
end

#public static final String theFilename = "hello.txt";
#13:   public static final String message = "Hello, world!\n";
#14:
#15:   public static void main (String [] args) throws IOException {
#16:
#17:     Configuration conf = new Configuration();
#18:     FileSystem fs = FileSystem.get(conf);
#19:
#20:     Path filenamePath = new Path(theFilename);
#21:
#22:     try {
#23:       if (fs.exists(filenamePath)) {
#24:         // remove the file first
#25:         fs.delete(filenamePath);
#26:       }
#27:
#28:       FSDataOutputStream out = fs.create(filenamePath);
#29:       out.writeUTF(message;
#30:       out.close();
#31:
#32:       FSDataInputStream in = fs.open(filenamePath);
#33:       String messageIn = in.readUTF();
#34:       System.out.print(messageIn);
#35:       in.close();
#46:     } catch (IOException ioe) {
#47:       System.err.println("IOException during operation: " + ioe.toString());
#48:       System.exit(1);
#49:     }
#40:   }