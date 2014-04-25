deck36_common
==============

Some common erlang modules, types and macros used by DECK36.

common_types.hrl
-----------------
Some types that help writing specs more readable. E.g. reason(), void(), ignored().


deck36_types.hrl
-----------------
Types used in this package.


deck36_macros.hrl
------------------
Well... some macros


deck36_common.hrl
------------------
Includes common_types.hrl, deck36_types.hrl, deck36_macros.hrl 


deck36_node
------------
Configure the current node.

configure/0, configure/1 configure the current node according to an app environment or a given proplist. They currently only set the cookie.

set_cookie/1, set_cookie/2 allow setting of cookies by atom, list, binary or file.


deck36_pulse
-------------
Generate and convert a pulse.

If you don't know what the pulse is, never mind. Will blog about it later.


deck36_time
------------
Time measurement and conversion functions.


deck36_inet
------------
Some inet helpers.


deck36_test_util
-----------------
Some utils to help writing tests.


Further Information
--------------------
CI with travis: https://travis-ci.org/DECK36/deck36_common

See modules for further information.

