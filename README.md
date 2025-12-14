# no-error-kafka

This repository stores my investigation related to
<https://github.com/checkstyle/checkstyle/issues/16003>. That issue discussed adding Apache Kafka to
Checkstyle’s regression suite. The main problem was that running Checkstyle on Kafka’s codebase was
memory intensive and repeatedly caused out-of-memory errors in CI.

This repository collects my experiments aimed at understanding and reducing the memory usage of that
CI job. I tried several approaches, measured their impact, and kept snapshots of the results along
the way. Each folder inside the `archives/` directory corresponds to one point in time during this
investigation and contains:

- `docker-stats.csv`: Memory and CPU usage statistics collected during the CI job run.
- `validation.sh` (or `no-error-kafka.sh`): The script used to run Checkstyle on Kafka’s codebase.
- `performance-plot.png`: A plot visualizing memory and CPU usage over time during the CI job run.

All of these directories were generated automatically by running `./run-no-error-kafka.sh` from the
root of this repository. The `visualizations.ipynb` notebook is used to generate the
`performance-plot.png` files from the corresponding `docker-stats.csv` files.

The underlying issue was later addressed in <https://github.com/checkstyle/checkstyle/pull/18263>.

## Execution

Set up your Python environment via:

```bash
pipenv sync
pipenv shell
```

And then simply run:

```bash
# Change paths in `run-no-error-kafka.sh` according to your environment.
./run-no-error-kafka.sh
```
