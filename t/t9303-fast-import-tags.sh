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
	git fast-import --export-marks=marks.out <input
'

test_expect_success 'can branch from tag' '
	test_tick &&
	cat >input <<-INPUT_END &&
	commit refs/heads/maint1
	committer $GIT_COMMITTER_NAME <$GIT_COMMITTER_EMAIL> $GIT_COMMITTER_DATE
	data <<COMMIT
	build on tag
	COMMIT

	from refs/tags/tag1
	M 644 inline file
	data <<EOF
	file content 2
	EOF

	INPUT_END
	git fast-import --export-marks=marks.out <input
'

test_expect_success 'can create and delete tag in same run' '
	test_tick &&
	cat >input <<-INPUT_END &&
	tag tag2
	from refs/heads/master
	data <<EOF
	a second tag
	EOF

	reset refs/tags/tag2
	from 0000000000000000000000000000000000000000

	INPUT_END
	git fast-import --export-marks=marks.out <input &&
	git tag -l tag2 >output &&
	test_must_be_empty output
'

test_done
