window.BENCHMARK_DATA = {
  "lastUpdate": 1760222256367,
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
          "id": "d02b286afee231dd5c8e5aacf859b601dd065e72",
          "message": "chore: untrack benchmarks/Manifest.toml and update .gitignore",
          "timestamp": "2025-10-12T00:08:23+02:00",
          "tree_id": "9a29f68582328f8cc2c76518a9d821ee0ee97131",
          "url": "https://github.com/albertomercurio/DeviceSparseArrays.jl/commit/d02b286afee231dd5c8e5aacf859b601dd065e72"
        },
        "date": 1760220787939,
        "tool": "julia",
        "benches": [
          {
            "name": "Matrix-Vector Multiplication/COO [JLArray]",
            "value": 5743712,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/CSR [JLArray]",
            "value": 437440,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/CSC [JLArray]",
            "value": 3664648,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/COO [CPU]",
            "value": 5765763,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/CSR [CPU]",
            "value": 427447,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Vector Multiplication/CSC [CPU]",
            "value": 3688322,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Sparse-Dense dot [CPU]",
            "value": 125.15478841870824,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":898,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Sum [JLArray]",
            "value": 16.15330661322645,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":998,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Sparse-Dense dot [JLArray]",
            "value": 130.8890147225368,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":883,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Sparse Vector/Sum [CPU]",
            "value": 10.41041041041041,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/COO [JLArray]",
            "value": 258510894.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/CSR [JLArray]",
            "value": 46773748,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/CSC [JLArray]",
            "value": 279164951,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/COO [CPU]",
            "value": 259045762.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/CSR [CPU]",
            "value": 45850319,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Matrix-Matrix Multiplication/CSC [CPU]",
            "value": 279856837,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/COO [JLArray]",
            "value": 5133374,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/CSR [JLArray]",
            "value": 489652,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/CSC [JLArray]",
            "value": 436473,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/COO [CPU]",
            "value": 5085985,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/CSR [CPU]",
            "value": 487558,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Three-argument dot/CSC [CPU]",
            "value": 436633,
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
          "id": "1e93f3a6ef0d2833adaa7ad2746347197c47cc5d",
          "message": "refactor: restructure benchmarks to group by backend for better plotting",
          "timestamp": "2025-10-12T00:33:24+02:00",
          "tree_id": "c7883d7059d0be79d6cb8788742b3740577328f8",
          "url": "https://github.com/albertomercurio/DeviceSparseArrays.jl/commit/1e93f3a6ef0d2833adaa7ad2746347197c47cc5d"
        },
        "date": 1760222255384,
        "tool": "julia",
        "benches": [
          {
            "name": "Array/Matrix-Vector Multiplication/COO [CPU]",
            "value": 5881940,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Matrix-Vector Multiplication/CSR [CPU]",
            "value": 427329,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Matrix-Vector Multiplication/CSC [CPU]",
            "value": 3715280.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Sparse Vector/Sparse-Dense dot [CPU]",
            "value": 119.35185185185185,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":918,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Sparse Vector/Sum [CPU]",
            "value": 10.81081081081081,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Matrix-Matrix Multiplication/COO [CPU]",
            "value": 260271876,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Matrix-Matrix Multiplication/CSR [CPU]",
            "value": 47657130,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Matrix-Matrix Multiplication/CSC [CPU]",
            "value": 282831982.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Three-argument dot/COO [CPU]",
            "value": 4964301,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Three-argument dot/CSR [CPU]",
            "value": 491038,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "Array/Three-argument dot/CSC [CPU]",
            "value": 442457,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Matrix-Vector Multiplication/COO [JLArray]",
            "value": 5915924.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Matrix-Vector Multiplication/CSR [JLArray]",
            "value": 429062,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Matrix-Vector Multiplication/CSC [JLArray]",
            "value": 3734859.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Sparse Vector/Sum [JLArray]",
            "value": 10.52052052052052,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":999,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Sparse Vector/Sparse-Dense dot [JLArray]",
            "value": 127.2474804031355,
            "unit": "ns",
            "extra": "gctime=0\nmemory=0\nallocs=0\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":893,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Matrix-Matrix Multiplication/COO [JLArray]",
            "value": 257381072.5,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1808\nallocs=34\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Matrix-Matrix Multiplication/CSR [JLArray]",
            "value": 46263301,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Matrix-Matrix Multiplication/CSC [JLArray]",
            "value": 278984833,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1792\nallocs=33\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Three-argument dot/COO [JLArray]",
            "value": 5054126,
            "unit": "ns",
            "extra": "gctime=0\nmemory=3672\nallocs=32\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Three-argument dot/CSR [JLArray]",
            "value": 490467,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          },
          {
            "name": "JLArray/Three-argument dot/CSC [JLArray]",
            "value": 440804,
            "unit": "ns",
            "extra": "gctime=0\nmemory=1952\nallocs=31\nparams={\"gctrial\":true,\"time_tolerance\":0.05,\"evals_set\":false,\"samples\":10000,\"evals\":1,\"gcsample\":false,\"seconds\":5,\"overhead\":0,\"memory_tolerance\":0.01}"
          }
        ]
      }
    ]
  }
}