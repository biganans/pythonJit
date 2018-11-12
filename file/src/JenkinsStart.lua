-- package.path = arg[1] .. "/src/?.lua;" .. package.path
package.path = "./src/?.lua;" .. package.path

require("src.Check")
