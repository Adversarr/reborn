add_requires("spdlog", {config={fmt="external"}})


target("mide")
    add_rules("qt.widgetapp")
    add_headerfiles("*.h")
    add_includedirs("../mias/src")
    add_files("*.cpp")
    add_files("mainwindow.ui")
    -- add files with Q_OBJECT meta (only for qt.moc)
    add_files("mainwindow.h")
    add_deps('mias-lib')
