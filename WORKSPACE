workspace(name = "ovbug")

new_local_repository(
    name = "openvino",
    build_file_content = """
cc_library(
    name = "openvino",
    srcs = glob([
                "inference_engine/lib/intel64/*.so",
                "ngraph/lib/libngraph.so",
                "ngraph/lib/libonnx_importer.so",
                "inference_engine/external/**/*.so*"]),
    hdrs = glob([
        "inference_engine/include/**/*.h",
        "inference_engine/include/**/*.hpp"
    ]),
    data = [ "inference_engine/lib/intel64/plugins.xml" ],
    strip_include_prefix = "inference_engine/include",
    visibility = ["//visibility:public"],
)
""",
    path = "/opt/intel/openvino/deployment_tools",
)

