# Run benchmark on each binary/script inside ./bin/

for file in ./bin/*; do
	# Have file name of binary relative to cwd
	extension="${file##*.}"
	if [[ $extension == "rb" ]]; then
		echo $file
		ruby $file
	fi
	if [[ $extension != "rb" ]]; then
		echo $file
		$file "postgres://localhost:5432/test?prepared_statements=false&initial_pool_size=1&max_pool_size=1&max_idle_pool_size=1"
	fi
done

