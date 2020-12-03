# photo_sorter
simple script to categorize your media (photo/video) to chronology tree 

```
carton exec perl photo_sort.pl --link unsorted_photo sorted_photo
```

`--link` is really fast (use hardlinks, so source and destination must be same physical drive)

## isort
wrapper around the [feh](https://feh.finalrewind.org) as fast viewer

(`pqiv` replacement)

```
./isort sorted_photo 
```

predefined actions

* `1` - move file to `deleted` directory (as a candidates for delete)
* `2` - make hardlink to `selected` category

in left down corner shows path to file when is picture in `selected`
