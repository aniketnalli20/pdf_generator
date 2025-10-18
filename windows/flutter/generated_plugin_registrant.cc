//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <pdf_combiner/pdf_combiner_plugin_c_api.h>
#include <pdfx/pdfx_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PdfCombinerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PdfCombinerPluginCApi"));
  PdfxPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PdfxPlugin"));
}
