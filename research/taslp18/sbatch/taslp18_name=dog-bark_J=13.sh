# This shell script executes the Slurm jobs for computing reconstructions.

sbatch taslp18_name=dog-bark_sc=none_J=13_wav=gammatone.sbatch
sbatch taslp18_name=dog-bark_sc=time_J=13_wav=gammatone.sbatch
sbatch taslp18_name=dog-bark_sc=time-frequency_J=13_wav=gammatone.sbatch
