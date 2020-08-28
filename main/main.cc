#include <ctime>
#include <string>
#include <iostream>

#include <inference_engine.hpp>


void print_localtime() {
  std::time_t result = std::time(nullptr);
  std::cout << std::asctime(std::localtime(&result));
}

int main(int argc, char** argv) {
    print_localtime();
          
    InferenceEngine::Core engine;
    InferenceEngine::CNNNetwork network;

    network = engine.ReadNetwork("/model/squeezenet1.1.xml");
    engine.LoadNetwork(network, "GPU");

    std::cout << "model loaded" << std::endl;
  
    return 0;
}
