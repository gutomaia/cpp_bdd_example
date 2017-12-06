#include <pybind11/pybind11.h>

#include "example.c"


namespace py = pybind11;

PYBIND11_MODULE(example, m){
    m.doc() = "pybind 11 example plugin";
    m.def("add", &add, "Afunction witch adds two numbers");
}
