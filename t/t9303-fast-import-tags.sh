#!/bin/sh
test_description='test git fast-import tag handling'
. ./test-lib.sh

test_expect_success 'can update tag' '
	test_tick &&
	cat >input <<-INPUT_END &&
	commit refs/heads/master
	committer $GIT_COMMITTER_NAME <$GIT_COMMITTER_EMAIL> $GIT_COMMITTER_DATE
	data <<COMMIT
	initial
	COMMIT

	M 644 inline file
	data <<EOF
	file content
	EOF

	tag tag1
	from refs/heads/master
	data <<EOF
	a tag
	EOF

	commit refs/heads/master
	committer $GIT_COMMITTER_NAME <$GIT_COMMITTER_EMAIL> $GIT_COMMITTER_DATE
	data <<COMMIT
	second
	COMMIT

	M 644 inline file
	data <<EOF
	file content 2
	EOF

	tag tag1
	from refs/heads/master
	data <<EOF
	An update to tag1
	EOF

	INPUT_END
	git fast-import --export-marks=marks.out <input &&
	echo "tag1" >expected &&
	git tag -l >actual &&
	test_cmp expected actual
'

test_done
