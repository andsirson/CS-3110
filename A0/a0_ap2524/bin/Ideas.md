# General Ideas about Project:
Requirements:
## Pet thinking
Pet object:
    Fullness
    Happiness
    Energy
-       Clamped between 0, 100
    Wellness - autocalculated/evaluated based on other stats
    Note: save current status, e.g. "thriving" in pet?
    Ascii art: https://www.asciiart.eu/animals/cats
    Prob use records with "with"

Pros of storing all stuff in pet:
- Easy to access 
- Clear what things are
Cons:
- Inefficient at "stroage" ig
- Need to think about race conditions: update happiness, etc. then you can use final wellness
- Type might get bloated

### How would I hhandlke many pets?
Need an arbitrary amount, so pet1,pet2,pet3 isnt that good
Pet list maybe? then just "replace" spot in list?
Actually, only one pet needed (i think) so just shadowing pet var should work

## Separate "handling" section
need to handle commands, "turns," define a full turn


- note:
two ways to handle all these types: could do associative lists, could do somethihng esle, but need to make clear wy i did it that way

Actually, probabily easier to have a sep ml with strings

maybe just 

TODO: add welcome, outro
