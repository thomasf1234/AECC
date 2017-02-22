require 'imdb'

module Tables
  class RunningEmulators < IMDB::Table
    define_columns do
      column :android_serial, String
      column :port, Fixnum, unique: true
    end
  end
end
