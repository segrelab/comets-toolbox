%run with: res = runtests('testStridx.m')
function tests = testStridx
%arr = {'abc' 'ABC' 'cba' 'CBA' 'a.b.c' './\/?*./'};
tests = functiontests(localfunctions);
end

%if allowSubstr is not given, allow case insensitive matches anywhere
function testSubstrNotGiven(testCase)
arr = {'abc' 'ABC' 'cba' 'CBA' 'a.b.c' './\/?*./'};
expect1 = [1 2 3 4 5];
actual1 = stridx('a',arr);
verifyEqual(testCase,expect1,actual1);
expect2 = [1 2];
actual2 = stridx('BC',arr);
verifyEqual(testCase,expect2,actual2);
end

%treat the query literally, not as regex
function testSubstrLiteral(testCase)
arr = {'abc' 'ABC' 'cba' 'CBA' 'a.b.c' './\/?*./'};
expect1 = [6];
actual1 = stridx('?*',arr);
verifyEqual(testCase,expect1,actual1);
end

%if allowSubstr = true, expect the same behavior as if it was not given
function testSubstrTrue(testCase)
arr = {'abc' 'ABC' 'cba' 'CBA' 'a.b.c' './\/?*./'};
expect1 = [1 2 3 4 5];
actual1 = stridx('a',arr,true);
verifyEqual(testCase,expect1,actual1);
expect2 = [1 2];
actual2 = stridx('BC',arr);
verifyEqual(testCase,expect2,actual2);
end

%if allowSubstr = false, only get case sensitive complete matches
function TestSubstrFalse(testCase)
arr = {'abc' 'ABC' 'cba' 'CBA' 'a.b.c' './\/?*./'};
expect1 = [1 5];
actual1 = stridx('a',arr,false);
verifyEqual(testCase,expect1,actual1);
%expect2 = [];
actual2 = stridx('BC',arr,false);
verifyEmpty(testCase,actual2);
end

