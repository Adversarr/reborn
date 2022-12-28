add_requires("spdlog", {configs={fmt_external=true}})

add_requires('magic_enum')
target('krill')
  set_kind("static")
  set_languages('cxx17')
  add_includedirs("krill/krill/include", {public = true})
  add_files("krill/krill/src/**.cpp")
  add_packages('spdlog', 'magic_enum', {public = true })

target('minic')
  set_kind('binary')
  set_languages('cxx17')
  add_files("krill/test/test_minic.cpp")
  add_deps('krill')

includes("mias")
includes("mide")

