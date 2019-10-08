#!/usr/bin/env bats
#shellcheck disable

load 'helpers/bats-support/load'
load 'helpers/bats-file/load'
load 'helpers/bats-assert/load'

rootDir="$(git rev-parse --show-toplevel)"
[[ "${rootDir}" =~ private ]] && rootDir="${HOME}/dotfiles"

filesToSource=(
  "${rootDir}/scripting/helpers/textProcessing.bash"
  "${rootDir}/scripting/helpers/baseHelpers.bash"
)
for sourceFile in "${filesToSource[@]}"; do
  [ ! -f "${sourceFile}" ] \
    && {
      echo "error: Can not find sourcefile '${sourceFile}'"
      echo "exiting..."
      exit 1
    }
  source "${sourceFile}"
  trap - EXIT INT TERM
done




# Set initial flags
quiet=false
printLog=false
logErrors=false
verbose=false
force=false
dryrun=false
declare -a args=()

@test "Sanity..." {
  run true

  assert_success
  assert_output ""
}

@test "_cleanString_: fail" {
  run _cleanString_
  assert_failure
}

@test "_cleanString_: lowercase" {
  run _cleanString_ -l "I AM IN CAPS"
  assert_success
  assert_output "i am in caps"
}

@test "_cleanString_: uppercase" {
  run _cleanString_ -u "i am in caps"
  assert_success
  assert_output "I AM IN CAPS"
}

@test "_cleanString_: remove white space" {
  run _cleanString_ -u "   i am     in caps   "
  assert_success
  assert_output "I AM IN CAPS"
}

@test "_cleanString_: remove spaces before/aftrer -_" {
  run _cleanString_ "word - another- word- another-word"
  assert_success
  assert_output "word-another-word-another-word"
}

@test "_cleanString_: alnum" {
  run _cleanString_ -a "  !@#$%^%& i am     in caps 12345 == "
  assert_success
  assert_output "i am in caps 12345"
}

@test "_cleanString_: alnum w/ spaces" {
  run _cleanString_ -as "this(is)a[string]"
  assert_success
  assert_output "this is a string"
}

@test "_cleanString_: alnum w/ spaces and dashes" {
  run _cleanString_ -as "this(is)a-string"
  assert_success
  assert_output "this is a-string"
}

@test "_cleanString_: user replacement" {
  run _cleanString_ -p "e,g" "there should be a lot of e's in this sentence"
  assert_success
  assert_output "thgrg should bg a lot of g's in this sgntgncg"
}

@test "_cleanString_: remove specified characters" {
  run _cleanString_ "there should be a lot of e's in this sentence" "e"
  assert_success
  assert_output "thr should b a lot of 's in this sntnc"
}

@test "_cleanString_: compound test 1" {
  run _cleanString_ -p "2,4" -au "  @#$%[]{} clean   a compound command ==23---- " "e"
  assert_success
  assert_output "CLAN A COMPOUND COMMAND 43-"
}

@test "_escape_" {
  run _escape_ "Here is some / text to & be - escape'd"
  assert_success
  assert_output "Here\ is\ some\ /\ text\ to\ &\ be\ -\ escape'd"
}

@test "_stopWords_: success" {
  run _stopWords_ "A string to be parsed"
  assert_success
  assert_output "string parsed"
}

@test "_stopWords_: success w/ user terms" {
  run _stopWords_ "A string to be parsed to help pass this test being performed by bats" "bats,string"
  assert_success
  assert_output "parsed pass performed"
}

@test "_stopWords_: No changes" {
  run _stopWords_ "string parsed pass performed"
  assert_success
  assert_output "string parsed pass performed"
}

@test "_stopWords_: fail" {
  run _stopWords_
  assert_failure
}

@test "_htmlEncode_" {
  run _htmlEncode_ "Here's some text& to > be h?t/M(l• en™codeç£§¶d"
  assert_success
  assert_output "Here's some text&amp; to &gt; be h?t/M(l&bull; en&trade;code&ccedil;&pound;&sect;&para;d"
}

@test "_htmlDecode_" {
  run _htmlDecode_ "&clubs;Here's some text &amp; to &gt; be h?t/M(l&bull; en&trade;code&ccedil;&pound;&sect;&para;d"
  assert_success
  assert_output "♣Here's some text & to > be h?t/M(l• en™codeç£§¶d"
}

@test "_lower" {
  local text="$(echo "MAKE THIS LOWERCASE" | _lower_)"

  run echo "$text"
  assert_output "make this lowercase"
}

@test "_ltrim_" {
  local text=$(_ltrim_ <<<"    some text")

  run echo "$text"
  assert_output "some text"
}

@test "_rtrim_" {
  local text=$(_rtrim_ <<<"some text    ")

  run echo "$text"
  assert_output "some text"
}

@test "_upper_" {
  local text="$(echo "make this uppercase" | _upper_)"

  run echo "$text"
  assert_output "MAKE THIS UPPERCASE"
}

@test "_urlEncode_" {
  run _urlEncode_ "Here's some.text%that&needs_to-be~encoded+a*few@more(characters)"
  assert_success
  assert_output "Here%27s%20some.text%25that%26needs_to-be~encoded%2Ba%2Afew%40more%28characters%29"
}

@test "_urlDecode_" {
  run _urlDecode_ "Here%27s%20some.text%25that%26needs_to-be~encoded%2Ba%2Afew%40more%28characters%29"
  assert_success
  assert_output "Here's some.text%that&needs_to-be~encoded+a*few@more(characters)"
}