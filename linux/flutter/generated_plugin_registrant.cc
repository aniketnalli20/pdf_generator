//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <pdf_combiner/pdf_combiner_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) pdf_combiner_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PdfCombinerPlugin");
  pdf_combiner_plugin_register_with_registrar(pdf_combiner_registrar);
}
