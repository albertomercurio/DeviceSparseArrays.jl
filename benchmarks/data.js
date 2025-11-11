window.BENCHMARK_DATA = {
  "lastUpdate": 1762898847048,
  "repoUrl": "https://github.com/albertomercurio/DeviceSparseArrays.jl",
  "entries": {
    "Benchmark Results": [
      {
        "commit": {
          "author": {
            "email": "alberto.mercurio96@gmail.com",
            "name": "Alberto Mercurio",
            "username": "albertomercurio"
          },
          "committer": {
            "email": "alberto.mercurio96@gmail.com",
            "name": "Alberto Mercurio",
            "username": "albertomercurio"
          },
          "distinct": true,
          "id": "c92197bc4ebf648dc55615b6548dffce4f51df50",
          "message": "Reorganize benchmark plot structure",
          "timestamp": "2025-10-12T00:45:43+02:00",
          "tree_id": "72acd4095860660697031a7bb15889f8d4dadd67",
          "url": "https://github.com/albertomercurio/DeviceSparseArrays.jl/commit/c92197bc4ebf648dc55615b6548dffce4f51df50"
        },
        "date": 1760223000253,
        "tool": "julia",
        "benches": [
          {
            "name": "Matrix-Vector Multiplication/Array/CSC",
            "value": 3686286,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/COO",
            "value": 5790724,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/CSR",
            "value": 428305,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSC",
            "value": 3676733,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/COO",
            "value": 5785273,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSR",
            "value": 429046,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sum",
            "value": 13.368368368368369,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sparse-Dense dot",
            "value": 117.55349344978166,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":916,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sum",
            "value": 16.9749498997996,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":998,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sparse-Dense dot",
            "value": 134.06514285714286,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":875,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSC",
            "value": 279585532.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/COO",
            "value": 258420302,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSR",
            "value": 45608215,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSC",
            "value": 278488650,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/COO",
            "value": 259216261,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSR",
            "value": 47762314,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSC",
            "value": 438114,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/COO",
            "value": 5019491,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSR",
            "value": 489048,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSC",
            "value": 437272,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/COO",
            "value": 5046019,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSR",
            "value": 490280.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "alberto.mercurio96@gmail.com",
            "name": "Alberto Mercurio",
            "username": "albertomercurio"
          },
          "committer": {
            "email": "alberto.mercurio96@gmail.com",
            "name": "Alberto Mercurio",
            "username": "albertomercurio"
          },
          "distinct": true,
          "id": "e69e015cf23382aa0bc2c73269e9827c43b6e4e6",
          "message": "Use 2 threads in benchmarks",
          "timestamp": "2025-10-12T00:54:42+02:00",
          "tree_id": "3fde7360e4d1beb3394c5a11ef10f0cd15d894b2",
          "url": "https://github.com/albertomercurio/DeviceSparseArrays.jl/commit/e69e015cf23382aa0bc2c73269e9827c43b6e4e6"
        },
        "date": 1760223532840,
        "tool": "julia",
        "benches": [
          {
            "name": "Matrix-Vector Multiplication/Array/CSC",
            "value": 3651601.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/COO",
            "value": 5660420,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/CSR",
            "value": 427010,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSC",
            "value": 3667913,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/COO",
            "value": 5675950,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSR",
            "value": 427285.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sum",
            "value": 10.66066066066066,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sparse-Dense dot",
            "value": 156.7945205479452,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":803,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sum",
            "value": 15.439879759519037,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":998,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sparse-Dense dot",
            "value": 132.42792281498296,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":881,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSC",
            "value": 279366383,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/COO",
            "value": 255943928.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSR",
            "value": 47663118,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSC",
            "value": 278657171.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/COO",
            "value": 257588860.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSR",
            "value": 47782524,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSC",
            "value": 436437,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/COO",
            "value": 4959822,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSR",
            "value": 489096.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSC",
            "value": 437770.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/COO",
            "value": 5166140,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSR",
            "value": 488715,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "61953577+albertomercurio@users.noreply.github.com",
            "name": "Alberto Mercurio",
            "username": "albertomercurio"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "f48e5e61eb5a30b42817944af97863ca0ee2b5b2",
          "message": "Define kernels globally (#14)\n\n* Separate kernels for CSC mul!\n\n* Use conj method propagation\n\n* Move kernels into a separate file\n\n* Move all the other kernels\n\n* Don't run quality tests on 1.12 version",
          "timestamp": "2025-11-11T21:23:45+01:00",
          "tree_id": "f460ad85a9e7c6f333b90fa2669647e38588e59b",
          "url": "https://github.com/albertomercurio/DeviceSparseArrays.jl/commit/f48e5e61eb5a30b42817944af97863ca0ee2b5b2"
        },
        "date": 1762892904800,
        "tool": "julia",
        "benches": [
          {
            "name": "Matrix-Vector Multiplication/Array/CSC",
            "value": 3643791,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/COO",
            "value": 5319758,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/CSR",
            "value": 428879.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSC",
            "value": 3635223,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/COO",
            "value": 5329012,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSR",
            "value": 430337,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sum",
            "value": 12.225225225225225,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sparse-Dense dot",
            "value": 105.30949839914621,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":937,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sum",
            "value": 14.455911823647295,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":998,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sparse-Dense dot",
            "value": 111.96871628910463,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":927,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSC",
            "value": 277846381.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/COO",
            "value": 247876389,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1824\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSR",
            "value": 48739631.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSC",
            "value": 278267624.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/COO",
            "value": 254158913.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1824\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSR",
            "value": 49517003,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSC",
            "value": 436353,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/COO",
            "value": 6147460.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3624\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSR",
            "value": 492254,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSC",
            "value": 437651,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/COO",
            "value": 5315799.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3624\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSR",
            "value": 493315,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      },
      {
        "commit": {
          "author": {
            "email": "61953577+albertomercurio@users.noreply.github.com",
            "name": "Alberto Mercurio",
            "username": "albertomercurio"
          },
          "committer": {
            "email": "noreply@github.com",
            "name": "GitHub",
            "username": "web-flow"
          },
          "distinct": true,
          "id": "fe56588fa2f882e9dd0c4b9285bb772bee906bbf",
          "message": "Merge pull request #15 from albertomercurio:patch-1\n\nReorganize folders",
          "timestamp": "2025-11-11T23:03:07+01:00",
          "tree_id": "3b262c2423ed5f5907e7304f2083004616779925",
          "url": "https://github.com/albertomercurio/DeviceSparseArrays.jl/commit/fe56588fa2f882e9dd0c4b9285bb772bee906bbf"
        },
        "date": 1762898846130,
        "tool": "julia",
        "benches": [
          {
            "name": "Matrix-Vector Multiplication/Array/CSC",
            "value": 3705982,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/COO",
            "value": 5450479,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/Array/CSR",
            "value": 427631,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSC",
            "value": 3711918.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/COO",
            "value": 5452851,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/JLArray/CSR",
            "value": 425528,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sum",
            "value": 12.285285285285285,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Array/Sparse-Dense dot",
            "value": 141.36013986013987,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":858,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sum",
            "value": 13.633266533066132,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":998,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/JLArray/Sparse-Dense dot",
            "value": 137.28143021914647,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":867,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSC",
            "value": 284336292.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/COO",
            "value": 256879509,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1824\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/Array/CSR",
            "value": 48804737,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSC",
            "value": 286071038.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/COO",
            "value": 256319835.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1824\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/JLArray/CSR",
            "value": 49521962,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSC",
            "value": 442119,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/COO",
            "value": 5089512,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3624\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/Array/CSR",
            "value": 492333,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSC",
            "value": 440495,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/COO",
            "value": 5059124.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3624\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/JLArray/CSR",
            "value": 491992,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1904\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}