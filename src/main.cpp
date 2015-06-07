#include "applicationui.hpp"

#include <bb/cascades/Application>

#include <QLocale>
#include <QTranslator>

#include <Qt/qdeclarativedebug.h>
#include <bb/data/DataSource>

using namespace bb::cascades;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);
    bb::data::DataSource::registerQmlTypes();
    ApplicationUI appui;
    return Application::exec();
}
