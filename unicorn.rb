# アプリケーションディレクトリ
@dir = "/Users/reo-dstar/work/git/go_library/"

# CPUのコア数を推奨
worker_processes 2 
working_directory @dir

timeout 300
# listen UNIXsocket
# listen "/path/to/app/tmp/unicorn.sock", backlog: 1024 # UNIXソケットを見るように変更
listen "/Users/reo-dstar/work/git/go_library/tmp/unicorn.sock", backlog: 1024 # UNIXソケットを見るように変更


# pid
pid "#{@dir}tmp/pids/unicorn.pid" 

# ログ出力
stderr_path "#{@dir}log/unicorn.stderr.log"
stdout_path "#{@dir}log/unicorn.stdout.log"

