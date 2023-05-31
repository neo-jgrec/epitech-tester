## dante tester

To test your dante project, you can use the following script :

```bash
./tester.sh
```

To test the script you'll need several things :
- A `solver` executable (working because it's the one used to generate the solved maps)
- And of course, the `tester.sh` script

### This part has also a txt_to_ppm script to convert txt into ppm images

The script will take as input a file containing a dante map, solved or not and will output the solution in a ppm image.

#### Usage

```bash
./txt_to_ppm.sh [input_file] [output_file]
```
