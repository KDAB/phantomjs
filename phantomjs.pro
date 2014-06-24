TEMPLATE = subdirs

SUBDIRS += src app
app.depends = src

build_javabindings {
    SUBDIRS += javabindings
    javabindings.depends = src
}
